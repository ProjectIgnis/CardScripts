--カオス・フォーム (Anime)
--Chaos Form (Anime)
local s,id=GetID()
function s.initial_effect(c)
	local ritual_params={handler=c,lvtype=RITPROC_EQUAL,filter=s.ritualfil}
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return (Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_BLUEEYES_W_DRAGON,CARD_DARK_MAGICIAN)
					and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp))
					or Ritual.Target(ritual_params)(e,tp,eg,ep,ev,re,r,rp,chk) end
				Ritual.Target(ritual_params)(e,tp,eg,ep,ev,re,r,rp,chk)
			end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_BLUEEYES_W_DRAGON,CARD_DARK_MAGICIAN)
					and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
					and (not Ritual.Target(ritual_params)(e,tp,eg,ep,ev,re,r,rp,0) or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
					if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
						sc:CompleteProcedure()
					end
				else
					Ritual.Operation(ritual_params)(e,tp,eg,ep,ev,re,r,rp)
				end
			end)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON,CARD_DARK_MAGICIAN}
function s.ritualfil(c)
	return c:IsSetCard({SET_CHAOS,SET_NUMBER_C}) and c:IsRitualMonster()
end
function s.spfilter(c,e,tp)
	return s.ritualfil(c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end