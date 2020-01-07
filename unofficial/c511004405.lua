--Performance Exchange
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--active
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x9f) and Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,0,1,c,c:GetLevel())
end
function s.ctfilter(c,lv)
	return c:IsFaceup() and c:GetLevel()>0 and c:GetLevel()<lv and c:IsControlerCanBeChanged()
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_MZONE,0,tc,tc:GetLevel())
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,#g,0,0)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv=tc:GetLevel()
		local ctg=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_MZONE,0,nil,lv)
		local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		local ct=math.min(#ctg,ft)
		if ct>0 then
			if #ctg>ct then
				ctg=ctg:Select(tp,ct,ct,nil)
			end
			Duel.GetControl(ctg,1-tp,RESET_PHASE+PHASE_END,1)
		end
	end
end
