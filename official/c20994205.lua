--ナンバーズ・エヴァイユ
--Numbers Eveil
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NUMBER}
function s.cfilter(c)
	return c:IsSpecialSummoned() and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)==0
end
function s.xyzfilter(c)
	return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ) and c.xyz_number
end
function s.spfilter(c,e,p,g)
	return Duel.GetLocationCountFromEx(p,p,g,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,p,false,false)
		and g:GetSum(function(mc)return mc.xyz_number end)==c.xyz_number
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetRank)==#sg and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,sg,e,tp,sg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #xg>4 and aux.SelectUnselectGroup(xg,e,tp,4,4,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if #xg<5 then return end
	local mg=aux.SelectUnselectGroup(xg,e,tp,4,4,s.rescon,1,tp,HINTMSG_XMATERIAL)
	if #mg~=4 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local spc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,mg,e,tp,mg):GetFirst()
	if spc and Duel.SpecialSummonStep(spc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP) then
		--Cannot Special Summon, except "Number" Xyz Monsters
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,0)
		e1:SetCondition(function(e) return e:GetHandler():GetControler()==e:GetLabel() end)
		e1:SetTarget(function(_,c) return not (c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ)) end)
		e1:SetLabel(tp)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		spc:RegisterEffect(e1,true)
		Duel.SpecialSummonComplete()
		spc:CompleteProcedure()
		if not spc:IsImmuneToEffect(e) then Duel.Overlay(spc,mg) end
	end
end