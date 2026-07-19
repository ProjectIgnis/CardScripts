--セネトの啓示者－ネフェルタリ
--Sennet Prophet - Nefertari
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can send it to the GY; show up to 2 Normal Monster Cards from your hand, Deck, face-up field, and/or GY, then Set that many "Sennet" Spells from your Deck
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SET)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetCost(Cost.SelfToGrave)
	e1a:SetTarget(s.settg)
	e1a:SetOperation(s.setop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--During your opponent's turn (Quick Effect): You can banish this card from your GY; equip 1 Normal Monster from your GY to 1 Ritual Monster you control as an Equip Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsTurnPlayer(1-tp)
	end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SENNET}
local LOCATIONS_HAND_DECK_ONFIELD_GRAVE=LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD|LOCATION_GRAVE
function s.showfilter(c)
	return c:IsOriginalType(TYPE_NORMAL) and (c:IsFaceup() or not c:IsOnField())
end
function s.setfilter(c)
	return c:IsSetCard(SET_SENNET) and c:IsSpell() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.showfilter,tp,LOCATIONS_HAND_DECK_ONFIELD_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local show_group=Duel.GetMatchingGroup(s.showfilter,tp,LOCATIONS_HAND_DECK_ONFIELD_GRAVE,0,nil)
	if #show_group==0 then return end
	local set_group=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if #set_group==0 then return end
	local szone_count=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local max_count=math.min(2,szone_count,#show_group,#set_group)
	if max_count<2 and set_group:IsExists(Card.IsFieldSpell,1,nil) then
		max_count=max_count+1
	end
	if max_count==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rg=Duel.SelectMatchingCard(tp,s.showfilter,tp,LOCATIONS_HAND_DECK_ONFIELD_GRAVE,0,1,max_count,nil)
	if #rg==0 then return end
	local confirm_group,hintselection_group=rg:Split(Card.IsLocation,nil,LOCATION_HAND|LOCATION_DECK)
	if #hintselection_group>0 then
		Duel.HintSelection(hintselection_group)
	end
	if #confirm_group>0 then
		Duel.ConfirmCards(1-tp,confirm_group)
		if confirm_group:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			Duel.ShuffleHand(tp)
		end
		if confirm_group:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
		end
	end
	local sg=aux.SelectUnselectGroup(set_group,e,tp,#rg,#rg,s.rescon(szone_count),1,tp,HINTMSG_SET)
	if #sg==#rg then
		Duel.BreakEffect()
		Duel.SSet(tp,sg)
	end
end
function s.rescon(szone_count)
	return function(sg,e,tp,mg)
		local fields,nonfields=sg:Split(Card.IsFieldSpell,nil)
		return #fields<=1 and #nonfields<=szone_count,#fields>1 and #nonfields>szone_count
	end
end
function s.eqfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRitualMonster),tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local eqc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if not eqc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ritc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsRitualMonster),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not ritc then return end
	Duel.HintSelection(eqc)
	Duel.HintSelection(ritc)
	if Duel.Equip(tp,eqc,ritc) then
		--Equip limit
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetCode(EFFECT_EQUIP_LIMIT)
		e0:SetValue(function(e,c) return c==ritc end)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		eqc:RegisterEffect(e0)
	end
end