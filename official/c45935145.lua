--死祖の隷竜ウォロー
--Wollow, Founder of the Drudge Dragons
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,6,2,nil,nil,Xyz.InfiniteMats)
	--Increase ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Shuffle, Special Summon, or Set the targeted card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
end
function s.val(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)*100
end
function s.tgfilter(c,e,tp,detach_1,detach_2)
	return (detach_1 and c:IsAbleToDeck()) or (detach_2 and (s.spfilter(c,e,tp) or s.setfilter(c)))
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP|POS_FACEDOWN_DEFENSE)
end
function s.setfilter(c)
	return c:IsSpellTrap() and c:IsSSetable()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local detach_1=c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	local detach_2=c:CheckRemoveOverlayCard(tp,2,REASON_COST)
	if chk==0 then return (detach_1 or detach_2) and Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,detach_1,detach_2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,detach_1,detach_2):GetFirst()
	local b1=detach_1 and tc:IsAbleToDeck()
	local b2=detach_2 and (s.spfilter(tc,e,tp) or s.setfilter(tc))
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		c:RemoveOverlayCard(tp,1,1,REASON_COST)
		e:SetCategory(CATEGORY_TODECK)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,tp,0)
	elseif op==2 then
		c:RemoveOverlayCard(tp,2,2,REASON_COST)
		if tc:IsMonster() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,0)
		else
			e:SetCategory(0)
			Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,tp,0)
		end
	end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if op==1 then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif op==2 then
		if tc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP|POS_FACEDOWN_DEFENSE)>0
			and tc:IsFacedown() then
			Duel.ConfirmCards(1-tp,tc)
		elseif tc:IsSSetable() then
			Duel.SSet(tp,tc)
		end
	end
end
