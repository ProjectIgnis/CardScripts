--スプライト・ダブルクロス
--Spright Double Cross
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 monster on the field and GY and activate 1 effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.atchfilter(c,tp)
	return c:IsMonster() and not c:IsType(TYPE_TOKEN)
		and (c:IsControler(tp) or c:IsLocation(LOCATION_GRAVE) or c:IsAbleToChangeControler())
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,c)
end
function s.xyzfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsRank(2) and c:IsFaceup()
end
function s.ctrlfilter(c,zone)
	return c:IsControlerCanBeChanged(false,zone)
end
function s.spfilter(c,e,tp,zone)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=aux.GetMMZonesPointedTo(tp,Card.IsLink,LOCATION_MZONE,0,nil,2)
	local b1=Duel.IsExistingTarget(s.atchfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,nil,tp)
	local b2=Duel.IsExistingTarget(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil,zone)
	local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,zone)
	if chkc then
		local label=e:GetLabel()
		if label==1 then
			return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.atchfilter(chkc,tp)
		elseif label==2 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctrlfilter(chkc,zone)
		elseif label==3 then
			return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,zone)
		end
	end
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.atchfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil,tp)
		if g:GetFirst():IsLocation(LOCATION_GRAVE) then
			Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
		end
	elseif op==2 then
		e:SetCategory(CATEGORY_CONTROL)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g=Duel.SelectTarget(tp,ctrlfilter,tp,0,LOCATION_MZONE,1,1,nil,zone)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,zone)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local zone=aux.GetMMZonesPointedTo(tp,Card.IsLink,LOCATION_MZONE,0,nil,2)
	local op=e:GetLabel()
	if op==1 then --Attach it to a Rank 2
		if not tc:IsImmuneToEffect(e) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,tc) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local xc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,tc):GetFirst()
			if xc then
				Duel.Overlay(xc,tc,true)
			end
		end
	elseif op==2 then --Gain control of it to a zone a Link 2 points to
		if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
			Duel.GetControl(tc,tp,0,0,zone)
		end
	else --Special summon it to a zone a Link 2 points to
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and zone>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
		end
	end
end