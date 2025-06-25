--聖刻龍－ドラゴンゲイヴ
--Hieratic Dragon of Gebeb
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Dragon Normal Monster from your hand, Deck, or GY, and make its ATK/DEF 0
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop(s.normalspfilter))
	e1:SetLabel(1)
	c:RegisterEffect(e1)
	--Special Summon 1 "Hieratic" Normal Monster from your hand, Deck, or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RELEASE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop(s.hieraticspfilter))
	c:RegisterEffect(e2)
end
s.listed_series={SET_HIERATIC}
function s.normalspfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.hieraticspfilter(c,e,tp)
	return c:IsSetCard(SET_HIERATIC) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(spfilter)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
				if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) and e:GetLabel()==1 then
					--Make its ATK/DEF 0
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetCode(EFFECT_SET_ATTACK)
					e1:SetValue(0)
					e1:SetReset(RESET_EVENT|RESETS_STANDARD)
					sc:RegisterEffect(e1)
					local e2=e1:Clone()
					e2:SetCode(EFFECT_SET_DEFENSE)
					sc:RegisterEffect(e2)
				end
				Duel.SpecialSummonComplete()
			end
end