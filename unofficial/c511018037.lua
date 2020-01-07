--重力激変
--Gravity Fluctuation
local cid, id = GetID()
function cid.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
function cid.filter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and Duel.IsExistingMatchingCard(cid.dfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
function cid.dfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<=atk
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and cid.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	local tc=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local dg=Duel.GetMatchingGroup(cid.dfilter,tp,0,LOCATION_MZONE,nil,tc:GetFirst():GetAttack())
	dg=dg+tc
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,2,0,0)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local atk = tc:GetAttack()
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)
			local g=Duel.SelectMatchingCard(1-tp,cid.dfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
			if #g>0 then
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
