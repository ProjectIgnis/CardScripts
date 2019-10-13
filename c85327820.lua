--Ａｉの儀式
--A.I.'s Ritual
--Scripted by AlphaKretin, anime version by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x135}
function s.exfilter0(c)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741)
		and c:IsSetCard(0x135) and c:IsLevelAbove(1) and c:IsAbleToRemove()
end
function s.filter(c,e,tp,m1,m2,ft)
	if not c:IsRace(RACE_CYBERSE) or not c:IsRitualMonster()
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	mg:Merge(m2)
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,nil)
	end
	if ft>0 then
		return mg:CheckWithSumGreater(Card.GetRitualLevel,c:GetLevel(),c)
	else
		return ft>-1 and mg:IsExists(s.mfilterf,1,nil,tp,mg,c)
	end
end
function s.mfilterf(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
		Duel.SetSelectedCard(c)
		return mg:CheckWithSumGreater(Card.GetRitualLevel,rc:GetLevel(),rc)
	else return false end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(0)
		local mg1=Duel.GetRitualMaterial(tp):Filter(Card.IsSetCard,nil,0x135)
		local mg2=Group.CreateGroup()
		if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x135),tp,LOCATION_MZONE,0,1,nil) then
			e:SetLabel(1)
			mg2=Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_GRAVE,0,nil)
		end
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp,mg1,mg2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg1=Duel.GetRitualMaterial(tp):Filter(Card.IsSetCard,nil,0x135)
	local mg2=Group.CreateGroup()
	if e:GetLabel()==1 then
		e:SetLabel(0)
		mg2=Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_GRAVE,0,nil)
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND,0,1,1,nil,e,tp,mg1,mg2,ft):GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,nil)
		end
		local mat=nil
		if ft>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetLevel(),tc)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:FilterSelect(tp,s.mfilterf,1,1,nil,tp,mg,tc)
			Duel.SetSelectedCard(mat)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local mat2=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetLevel(),tc)
			mat:Merge(mat2)
		end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
