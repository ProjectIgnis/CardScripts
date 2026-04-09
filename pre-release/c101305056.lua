--予幻なき日々のまぼろし
--Pasto-Ral Theorealize
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If you control an "Artmage", "DoomZ", or "Elfnote" card: Special Summon 1 "Medius the Pure" from your hand or Deck, also your opponent cannot activate cards or effects when that monster is Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,{SET_ARTMAGE,SET_DOOMZ,SET_ELFNOTE}),tp,LOCATION_ONFIELD,0,1,nil) end)
	e1:SetTarget(s.mediussptg)
	e1:SetOperation(s.mediusspop)
	c:RegisterEffect(e1)
	--You can banish this card from your GY, then target 1 Fusion, Synchro, or Xyz Monster in your GY; Special Summon it to your zone a Link Monster points to
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.gysptg)
	e2:SetOperation(s.gyspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ARTMAGE,SET_DOOMZ,SET_ELFNOTE}
s.listed_names={CARD_MEDIUS_THE_PURE}
function s.mediusspfilter(c,e,tp)
	return c:IsCode(CARD_MEDIUS_THE_PURE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.mediussptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.mediusspfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.mediusspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.mediusspfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Also your opponent cannot activate cards or effects when that monster is Special Summoned
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_END)
		e1:SetOperation(function(e)
							Duel.SetChainLimitTillChainEnd(function(e,rp,tp) return tp==rp end)
							e:Reset()
						end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.gyspfilter(c,e,tp,zones)
	return c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zones)
end
function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zones=aux.GetMMZonesPointedTo(tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyspfilter(chkc,e,tp,zones) end
	if chk==0 then return zones>0 and Duel.IsExistingTarget(s.gyspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zones) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.gyspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zones)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.gyspop(e,tp,eg,ep,ev,re,r,rp)
	local zones=aux.GetMMZonesPointedTo(tp)
	if zones==0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zones)
	end
end