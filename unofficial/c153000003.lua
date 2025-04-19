--深海の戦士 (Deck Master)
--Deepsea Warrior (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	dme1:SetCode(EVENT_BE_BATTLE_TARGET)
	dme1:SetCondition(s.dmcon)
	dme1:SetOperation(s.dmop)
	DeckMaster.RegisterAbilities(c,dme1)
	--immune spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.econ)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI}
function s.econ(e)
	return Duel.IsEnvironment(CARD_UMI)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsDeckMaster(tp,id) and Duel.GetAttackTarget():IsControler(tp)
		and Duel.CheckReleaseGroupCost(tp,nil,2,false,aux.ReleaseCheckTarget,nil,Group.FromCards(Duel.GetAttacker()))
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	local at=Duel.GetAttacker()
	local g=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,aux.ReleaseCheckTarget,nil,Group.FromCards(at))
	Duel.Release(g,REASON_COST)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.BreakEffect()
	if Duel.NegateAttack() then
		Duel.Damage(1-tp,at:GetAttack(),REASON_EFFECT)
	end
end