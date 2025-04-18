--死の王 ヘル
--Hela, Generaider Boss of Doom
--Scripted by Hel
local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Hela, Generaider Boss of Doom"
	c:SetUniqueOnField(1,0,id)
	--Special Summon 1 "Generaider" monster or 1 Zombie monster from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={SET_GENERAIDER}
function s.spcostfilter(c,e,tp)
	return (c:IsSetCard(SET_GENERAIDER) or c:IsRace(RACE_ZOMBIE)) and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,code)
	return (c:IsSetCard(SET_GENERAIDER) or c:IsRace(RACE_ZOMBIE)) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.spcostfilter,1,false,aux.ReleaseCheckMMZ,nil,e,tp) end
	local rc=Duel.SelectReleaseGroupCost(tp,s.spcostfilter,1,1,false,aux.ReleaseCheckMMZ,nil,e,tp):GetFirst()
	e:SetLabel(rc:GetCode())
	Duel.Release(rc,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local label=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,label) end
	if chk==0 then
		local res=label==-100
		e:SetLabel(0)
		return res
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,label)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
