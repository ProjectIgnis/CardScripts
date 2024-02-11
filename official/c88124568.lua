--ＳＰＹＲＡＬ－ダブルフェイク
--SPYRAL Double Agent
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself to the opponent's field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcond)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--"SPYRAL" monsters gain 500 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(function(e,_c) return _c:IsSetCard(SET_SPYRAL) end)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--"SPYRAL Super Agent" can attack directly
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(function(e,_c) return _c:IsCode(41091257) end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SPYRAL}
s.listed_names={41091257} --SPYRAL Super Agent
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SPYRAL),tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sdg=Duel.GetDecktopGroup(tp,1)
	local odg=Duel.GetDecktopGroup(1-tp,1)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
		and #sdg>0 and #odg>0 and not sdg:GetFirst():IsPublic() and not odg:GetFirst():IsPublic()
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)>0 then
		--Cannot be Tributed
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		c:RegisterEffect(e2)
		--Cannot be used as material for a Fusion, Synchro, Xyz, or Link Summon
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e3:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e3)
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 or Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)==0 then return end
		Duel.BreakEffect()
		Duel.ConfirmDecktop(tp,1)
		Duel.ConfirmDecktop(1-tp,1)
	end
end