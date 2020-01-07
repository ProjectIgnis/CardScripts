--Darkness/Monster A
--Darkness Outsider
local s,id=GetID()
function s.initial_effect(c)
	--no type/attribute/level
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	c:RegisterEffect(e2)
	c:SetStatus(STATUS_NO_LEVEL,true)
	--effect 1
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.mark=0
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) 
end
function s.filter(c,ft)
	return c:IsControlerCanBeChanged() and (ft>0 or c:GetSequence()<5)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,0)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,ft) end 
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,ft) 
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 and Duel.IsPlayerCanSpecialSummon(tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,0,LOCATION_DECK,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
	if #g>0 then 
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local zone=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)>>16
	if tc and tc:IsRelateToEffect(e) and Duel.GetControl(tc,1-tp,0,0,zone) then
		local g=Duel.GetMatchingGroup(s.spfilter,tp,0,LOCATION_DECK,nil,e,tp) 
		if #g>0 then
			Duel.ConfirmCards(tp,g)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sp=g:Select(tp,1,1,nil):GetFirst()
			Duel.BreakEffect()
			Duel.SpecialSummon(sp,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end