--神霊剣アイワス
--Spirit Sword Aiwass
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects; you cannot declare attacks for the rest of this turn, except with Fusion Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={101305016} --"Aiwass the Spirit of the Law"
s.listed_series={SET_ALEISTER}
function s.spfilter(c,e,tp)
	return c:IsCode(101305016) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tgbanfilter(c)
	return c:IsSetCard(SET_ALEISTER) and c:IsMonster() and (c:IsAbleToGrave() or c:IsAbleToRemove())
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--● Special Summon 1 "Aiwass the Spirit of the Law" from your Deck or GY
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)
	--● Send to the GY, or banish, 1 "Aleister" monster from your Deck
	local b2=Duel.IsExistingMatchingCard(s.tgbanfilter,tp,LOCATION_DECK,0,1,nil)
	--● Look at 3 random face-down cards in your opponent's Extra Deck, and if you do, banish 1 of them
	local b3=Duel.IsExistingMatchingCard(aux.AND(Card.IsFacedown,Card.IsAbleToRemove),tp,0,LOCATION_EXTRA,3,nil)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	elseif op==3 then
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Special Summon 1 "Aiwass the Spirit of the Law" from your Deck or GY
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif op==2 then
		--● Send to the GY, or banish, 1 "Aleister" monster from your Deck
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		local sc=Duel.SelectMatchingCard(tp,s.tgbanfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if sc then
			op=Duel.SelectEffect(tp,
				{sc:IsAbleToGrave(),aux.Stringid(id,5)},
				{sc:IsAbleToRemove(),aux.Stringid(id,6)})
			if op==1 then
				Duel.SendtoGrave(sc,REASON_EFFECT)
			elseif op==2 then
				Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)
			end
		end
	elseif op==3 then
		--● Look at 3 random face-down cards in your opponent's Extra Deck, and if you do, banish 1 of them
		local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA):RandomSelect(tp,3)
		if #g>0 then
			Duel.ConfirmCards(tp,g)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
			if #rg>0 then
				Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
			end
			Duel.ShuffleExtra(1-tp)
		end
	end
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,7))
	--You cannot declare attacks for the rest of this turn, except with Fusion Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return not c:IsFusionMonster() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end