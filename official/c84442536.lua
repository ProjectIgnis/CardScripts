--グレイドル・コンバット
--Graydle Combat
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xd1}
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0xd1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return s.cfilter(tc,tp) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc and (Duel.IsChainNegatable(ev) or tc:IsLocation(LOCATION_MZONE)) end
	local sel=0
	if Duel.IsChainNegatable(ev) and tc:IsLocation(LOCATION_MZONE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		sel=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif tc:IsLocation(LOCATION_MZONE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		sel=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		sel=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(sel)
	if sel==1 then
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
		if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		Duel.ChangeChainOperation(ev,s.repop)
	else
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
	if e:IsActiveType(TYPE_SPELL+TYPE_TRAP) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		c:CancelToGrave(false)
	end
end
