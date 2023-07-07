use miette::{Diagnostic, SourceSpan};
use snafu::Snafu;

/// The public error type used to report errors.
#[derive(Clone, Debug, PartialEq, Eq, Snafu, Diagnostic)]
pub enum AssemblerError {
    /// An opcode does not exist for an instruction.
    #[snafu(display("Opcode '{}' does not exist.", opcode))]
    #[diagnostic(
        code(nand7400asm::errors::opcode_does_not_exist),
        help("Try using a different opcode.")
    )]
    OpcodeDNE {
        /// The opcode that does not exist.
        opcode: String,

        /// The span of the opcode in the source code.
        #[label]
        span: SourceSpan,
    },

    /// A label does not exist for an argument.
    #[snafu(display("Label '{}' does not exist.", label))]
    #[diagnostic(
        code(nand7400asm::errors::label_does_not_exist),
        help("Try defining this label somewhere else in your code.")
    )]
    LabelDNE {
        /// The label that does not exist.
        label: String,
    },
}