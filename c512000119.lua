--サイクロン
--MST (DN)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={5318639}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,TYPE_SPELL+TYPE_TRAP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetChainLimit(s.chainlm)
end
function s.chainlm(e,rp,tp)
	return tp==rp or e:GetHandler():IsCode(5318639)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	if Duel.GetCurrentChain()>1 then
		for i=1,Duel.GetCurrentChain()-1 do
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			local tc=te:GetHandler()
			if tc then
				g:AddCard(tc)
				tc:RegisterFlagEffect(51200119,RESET_CHAIN,0,1,i)
			end
		end
	end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if g:IsContains(tc) then
			local i=tc:GetFlagEffectLabel(51200119)
			Duel.NegateActivation(i)
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e3)
			end
			Duel.BreakEffect()
		end
		Duel.Destroy(tc,REASON_EFFECT)
	end
end