--魔鍵疑—羅一
--Magikey Lock - Unlock
--scripted by XyleN5967
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x262}
function s.cfilter(c) 
	return c:IsFaceup() and c:IsSetCard(0x262) and (c:IsType(TYPE_RITUAL) or c:IsSummonLocation(LOCATION_EXTRA))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.attfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=0x7f
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.attfilter,tp,0,LOCATION_MZONE,nil)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		and Duel.Destroy(eg,REASON_EFFECT)~=0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		local share=0
		for tc in aux.Next(g) do
			if g:IsExists(function(c,tc) return c:GetAttribute()&tc:GetAttribute()>0 end,#g-1,tc,tc) then
				if tc:GetAttribute()&share==0 then share=share+(share~tc:GetAttribute()) end
			end
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
		local val=Duel.AnnounceAttribute(tp,1,~share)
		for tc in aux.Next(g) do
			--Change Attribute
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(val)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1) 
		end
	end
end