--Performance Dragon's Shadow
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x9f}
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated())
end
function s.cfilter(c,tp)
	return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c,tp,c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,tp)
	Duel.Release(g,REASON_COST)
end
function s.filter1(c,tp,rc)
	local g=Group.CreateGroup()
	if rc then
		g:AddCard(rc)
	end
	g:AddCard(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,g)
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND) then
		ft=ft-1
	end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetValue(1)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	Duel.RegisterEffect(e2,tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,tc)
		local ec=g:GetFirst()
		if ec then
			Duel.HintSelection(g)
			local atk=ec:GetTextAttack()
			if ec:IsFacedown() or atk<0 then atk=0 end
			if Duel.Equip(tp,ec,tc,true) then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_EQUIP_LIMIT)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				e3:SetValue(s.eqlimit)
				e3:SetLabelObject(tc)
				ec:RegisterEffect(e3)
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_EQUIP)
				e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e4:SetCode(EFFECT_UPDATE_ATTACK)
				e4:SetReset(RESET_EVENT+RESETS_STANDARD)
				e4:SetValue(atk)
				ec:RegisterEffect(e4)
				local fid=c:GetFieldID()
				ec:RegisterFlagEffect(51104430,RESET_EVENT+RESETS_STANDARD,0,1,fid)
				local e5=Effect.CreateEffect(c)
				e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e5:SetCode(EVENT_PHASE+PHASE_END)
				e5:SetCountLimit(1)
				e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e5:SetLabel(fid)
				e5:SetLabelObject(ec)
				e5:SetCondition(s.spcon)
				e5:SetOperation(s.spop)
				Duel.RegisterEffect(e5,tp)
			end
		end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.spcon(e,tp,eg,ev,ep,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(51104430)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function s.spop(e,tp,eg,ev,ep,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.SpecialSummon(e:GetLabelObject(),0,tp,tp,false,false,POS_FACEUP)
end
