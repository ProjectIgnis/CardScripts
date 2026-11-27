--白の繁栄
--White Prosperity
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon up to 2 Level 4 or lower WATER monsters from your hand, then if you control 2 or more monsters with the same name, you can treat 1 of them as a Tuner
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If a WATER monster(s) is Special Summoned from your GY while this card is in your GY, and you have another monster in your field or GY with the same name as 1 of them: You can banish this card from your GY; draw 2 cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.drawcond)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.namefilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),tp,LOCATION_MZONE,0,1,c)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local max_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if max_count<=0 then return end
	max_count=math.min(2,max_count)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then max_count=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,max_count,nil,e,tp)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.GetMatchingGroup(s.namefilter,tp,LOCATION_MZONE,0,nil,tp)
		if #g>=2 and g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_TUNER) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
			local sc=g:FilterSelect(tp,aux.NOT(Card.IsType),1,1,nil,TYPE_TUNER):GetFirst()
			if not sc then return end
			Duel.HintSelection(sc)
			Duel.BreakEffect()
			--Then if you control 2 or more monsters with the same name, you can treat 1 of them as a Tuner
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetValue(TYPE_TUNER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
	end
end
function s.drawcondfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,c)
end
function s.drawcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drawcondfilter,1,nil,tp)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end