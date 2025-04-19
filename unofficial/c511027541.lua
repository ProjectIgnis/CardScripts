--ＳＲ三ツ目のダイス (Anime)
--Speedroid Tri-Eyed Dice (Anime)
--Made by When
local s,id=GetID()
function s.initial_effect(c)
	--Negate attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.negcon)
	e1:SetCost(Cost.SelfBanish)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end