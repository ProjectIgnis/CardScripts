--マジシャンズ・クロス (Anime)
--Magicians Unite (Anime)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Change ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:GetAttackedCount()==0 and c:CanAttack()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,2,2,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,LOCATION_MZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	for tc in g:Iter() do
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,0)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local selected_monster=g:Select(tp,1,1,nil):GetFirst()
	g:RemoveCard(selected_monster)
	local other_monster=g:GetFirst()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(3000)
	selected_monster:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(3206)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	other_monster:RegisterEffect(e2)
	--Destroy those monsters by the same reason
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	Duel.RegisterEffect(e3,tp)
end
function s.desfilter(c)
	return c:HasFlagEffect(id) and c:IsReason(REASON_DESTROY)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.desfilter,nil)
	local dg=Duel.GetMatchingGroup(Card.HasFlagEffect,tp,LOCATION_MZONE,0,g,id)
	if #dg>0 then
		Duel.Destroy(dg,g:GetFirst():GetReason())
	else
		return
	end
	e:Reset()
end
