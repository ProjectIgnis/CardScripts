--AlphaKretin Custom Utility Token
--Scripted by a mysterious stranger
local s, id = GetID()
function s.initial_effect(c)
    --alph = {}

    --General

    --Misc useful constants
    DESC_GAIN_ATK = aux.Stringid(89194033, 0)
    DESC_SEARCH = aux.Stringid(85115440, 1)
    DESC_SUM_TOKEN = aux.Stringid(44586426, 1)
    DESC_BANISH = aux.Stringid(72989439, 1)
    DESC_DESTROY = aux.Stringid(48905153, 1)
    DESC_SPECIAL_SUMMON = aux.Stringid(72989439, 0)
    DESC_NEGATE = aux.Stringid(74762582, 0)
    TYPES_TOKEN = TYPE_MONSTER + TYPE_NORMAL + TYPE_TOKEN

    --Batteryst

    --Batteryst-related constants
    SET_BATTERYST = 0xf37

    --utility function to determine if a card has ATK higher than its original ATK
    function Card.HasExcessAttack(c)
        return c:GetExcessAttack() > 0
    end

    --utility function to get the difference between a card's ATK and original ATK, if higher
    function Card.GetExcessAttack(c)
        return c:GetAttack() - c:GetBaseAttack()
    end

    --utility function to return a card with ATK higher than its original ATK to its original ATK and return the ATK lost
    function Card.DrainExcessAttack(c, isCost)
        local atk = c:GetAttack()
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        if isCost then
            e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        end
        e1:SetValue(c:GetBaseAttack())
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(e1)
        local newAtk = atk - c:GetAttack()
        return (newAtk > 0) and newAtk or 0
    end

    --The Mark

    --Mark-related constants
    SET_MARK = 0xf38
    CARD_ENGRAVER_MARK = 50078320
    CARD_TRUE_ESSENCE_MARK = 210310406

    --function to check "The Mark" archetype including OCG
    function Card.IsTheMark(c)
        return c:IsSetCard(SET_MARK) or c:IsCode(CARD_ENGRAVER_MARK)
    end

    function Card.IsLinkTheMark(c, ...)
        return c:IsSetCard(SET_MARK, ...) or c:IsSummonCode(nil,SUMMON_TYPE_LINK,c:GetControler(),CARD_ENGRAVER_MARK)
    end
end
