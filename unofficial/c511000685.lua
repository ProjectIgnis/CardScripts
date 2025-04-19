--ＷＲＵＭ－ホープ・フォース
--Double-Rank-Up-Magic Utopia Force
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={84013237}
function s.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsCode(84013237) and #c:GetOverlayGroup()>=2
		and (rk>0 or c:IsStatus(STATUS_NO_LEVEL))
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,2,nil,rk,e,tp,c)
end
function s.filter2(c,rk,e,tp,mc)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return c:IsType(TYPE_XYZ) and (c:IsRank(rk+1) or c:IsRank(rk+2))
		and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)>1
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_XYZ)
		return #pg<=0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and aux.CheckSummonGate(tp,2)
			and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_XYZ)
	if #pg>0 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if not aux.CheckSummonGate(tp,2) then return end
	local tc=Duel.GetFirstTarget()
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	local ov=tc:GetOverlayGroup()
	if #ov<2 then return end
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,tc:GetRank(),e,tp,tc)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,2,2,nil)
		aux.RankUpUsing(sg,84013237,aux.Stringid(id,1))
		local ct=Duel.SpecialSummon(sg,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		for spc in aux.Next(sg) do
			spc:CompleteProcedure()
		end
		if ct>1 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local ovg=ov:Select(tp,2,2,nil)
			Duel.SendtoGrave(ovg,REASON_EFFECT)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local ovsg=ovg:Select(tp,1,1,nil)
			local osg=sg:Select(tp,1,1,nil)
			ovg:Sub(ovsg)
			sg:Sub(osg)
			Duel.HintSelection(osg)
			Duel.Overlay(osg:GetFirst(),ovsg)
			Duel.HintSelection(sg)
			Duel.Overlay(sg:GetFirst(),ovg)
		end
	end
end