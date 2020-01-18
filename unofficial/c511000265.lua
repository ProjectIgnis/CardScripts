--Gorlag
local s,id=GetID()
function s.initial_effect(c)
	--check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(s.checkop)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	e1:SetLabelObject(g)
	g:KeepAlive()
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(s.checkop2)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24104865,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	--Gain ATK for Each Fire Monster
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetValue(s.val)
	c:RegisterEffect(e5)
	--Cannot Attack Directly
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.cfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*500
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local t=Duel.GetAttackTarget()
	if t and t~=c then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
function s.checkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==0 then return end
	local t=c:GetBattleTarget()
	local g=e:GetLabelObject():GetLabelObject()
	if c:GetFieldID()~=e:GetLabel() then
		g:Clear()
		e:SetLabel(c:GetFieldID())
	end
	if aux.bdgcon(e,tp,eg,ep,ev,re,r,rp) then
		g:AddCard(t)
		t:RegisterFlagEffect(51100265,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFieldID()==e:GetLabelObject():GetLabel()
end
function s.filter(c,e,tp)
	return c:GetFlagEffect(51100265)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject():GetLabelObject()
	if chk==0 then return g:IsExists(s.filter,1,nil,e,tp) end
	local dg=g:Filter(s.filter,nil,e,tp)
	g:Clear()
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,dg,#dg,0,0)
end
function s.sfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(s.sfilter,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if #sg>ft then sg=sg:Select(tp,ft,ft,nil) end
	local tc=sg:GetFirst()
	local c=e:GetHandler()
	for tc in aux.Next(sg) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		tc:RegisterFlagEffect(51100265,RESET_EVENT+RESETS_STANDARD,0,0)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_FIRE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
		c:CreateRelation(tc,RESET_EVENT+0x1020000)
	end
	Duel.SpecialSummonComplete()
end
function s.desfilter(c,rc)
	return c:GetFlagEffect(51100265)~=0 and rc:IsRelateToCard(c)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil,e:GetHandler())
	Duel.Destroy(dg,REASON_EFFECT)
end
