--JP Name
--Angelechy Opposition
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Choose 2 "Angelechy" monsters in your Extra Deck, with different names than the cards in your Spell & Trap Zone, Special Summon 1 of them in your opponent's Main Monster Zone, and place the other in your Spell & Trap Zone as a face-up Continuous Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.spplcost)
	e1:SetTarget(s.sppltg)
	e1:SetOperation(s.spplop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c)
		return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsSynchroMonster() and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK))
	end)
	--You can banish this card from your GY; shuffle up to 5 "Angelechy" cards into the Deck from your GY and/or banishment, except "Angelechy Opposition"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_ANGELECHY}
function s.spplcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--You cannot Special Summon from the Extra Deck the turn you activate this card, except LIGHT or DARK Synchro Monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c)
		return c:IsLocation(LOCATION_EXTRA) and not (c:IsSynchroMonster() and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK))
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spplfilter(c,...)
	return c:IsSetCard(SET_ANGELECHY) and not c:IsForbidden() and not (... and c:IsCode(...))
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) and Duel.GetLocationCountFromEx(1-tp,tp,nil,c,ZONES_MMZ)>0
end
function s.sppltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local stzone_needed=e:GetHandler():IsLocation(LOCATION_HAND) and 2 or 1
		if Duel.GetLocationCount(tp,LOCATION_SZONE,0)<stzone_needed then return false end
		local codes=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_STZONE,0,nil):GetClass(Card.GetCode)
		local g=Duel.GetMatchingGroup(s.spplfilter,tp,LOCATION_EXTRA,0,nil,codes)
		return #g>1 and g:IsExists(s.spfilter,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spplrescon(sg,e,tp)
	return sg:IsExists(s.spfilter,1,nil,e,tp)
end
function s.spplop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE,0)<1 then return end
	local codes=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_STZONE,0,nil):GetClass(Card.GetCode)
	local g=Duel.GetMatchingGroup(s.spplfilter,tp,LOCATION_EXTRA,0,nil,codes)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.spplrescon,1,tp,aux.Stringid(id,3))
	if #sg~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local spc=sg:FilterSelect(tp,s.spfilter,1,1,nil,e,tp):GetFirst()
	local plc=(sg-spc):GetFirst()
	if spc and plc then
		Duel.SpecialSummon(spc,0,tp,1-tp,false,false,POS_FACEUP,ZONES_MMZ)
		if Duel.MoveToField(plc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			--Treated as a Continuous Spell
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			plc:RegisterEffect(e1)
		end
	end
end
function s.tdfilter(c)
	return c:IsSetCard(SET_ANGELECHY) and not c:IsCode(id) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,5,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end