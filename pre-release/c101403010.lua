--白鴉の騎士マルト
--Maluth the White Crow Knight
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--You can send 1 other card from your hand or field to the GY; place this card face-up in its owner's Spell & Trap Zone as a Continuous Spell, and if you do, Special Summon up to 2 "White Crow" monsters with different names from each other from your Deck, except "Maluth the White Crow Knight"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.placeandspcost)
	e1:SetTarget(s.placeandsptg)
	e1:SetOperation(s.placeandspop)
	c:RegisterEffect(e1)
	--When a monster declares an attack and this card is a Continuous Spell: You can target 1 "White Crow" Monster Card in your Spell & Trap Zone; Special Summon it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsContinuousSpell()
	end)
	e2:SetTarget(s.stzonesptg)
	e2:SetOperation(s.stzonespop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WHITE_CROW}
s.listed_names={id}
function s.costfilter(c,handler_mmz_chk,stzone_chk,tp,handler)
	return c:IsAbleToGraveAsCost() and ((c:IsLocation(LOCATION_STZONE) and handler_mmz_chk)
		or (stzone_chk and Duel.GetMZoneCount(tp,Group.FromCards(handler,c))>0))
end
function s.placeandspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local handler_mmz_chk=Duel.GetMZoneCount(tp,c)>0
	local stzone_chk=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c,handler_mmz_chk,stzone_chk,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c,handler_mmz_chk,stzone_chk,tp,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.deckspfilter(c,e,tp)
	return c:IsSetCard(SET_WHITE_CROW) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.placeandsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.placeandspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		--Treat this card as a Continuous Spell
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
		c:RegisterEffect(e1)
		local max_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if max_count<=0 then return end
		local g=Duel.GetMatchingGroup(s.deckspfilter,tp,LOCATION_DECK,0,nil,e,tp)
		if #g==0 then return end
		max_count=math.min(max_count,#g,2)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
			max_count=1
		end
		local sg=aux.SelectUnselectGroup(g,e,tp,1,max_count,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.stzonespfilter(c,e,tp)
	return c:IsSetCard(SET_WHITE_CROW) and c:IsMonsterCard() and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.stzonesptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_STZONE) and chkc:IsControler(tp) and s.stzonespfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.stzonespfilter,tp,LOCATION_STZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.stzonespfilter,tp,LOCATION_STZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.stzonespop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end