--クロス・チェンジ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tdfilter(c,sc,sc2,e,tp,ft)
	local lv=c:GetLevel()
	return c:IsSetCard(sc) and c:IsAbleToDeck() and (lv>0 or c:IsStatus(STATUS_NO_LEVEL)) and (not ft or ft>0 or c:GetSequence()<5)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,sc2,lv,e,tp)
end
function s.spfilter(c,sc,lv,e,tp)
	return c:IsSetCard(sc) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=-1 then return false end
	local con1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,0x3008,0x1f,e,tp,ft)
	local con2=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,0x1f,0x3008,e,tp,ft)
	if chk==0 then return con1 or con2 end
	local opt=0
	if con1 and con2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif con2 then
		opt=1
	end
	local sc
	if opt==0 then
		sc=0x3008001f
	else
		sc=0x1f3008
	end
	Duel.SetTargetParam(sc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local setcard=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local sc=setcard>>16
	local sc2=setcard&0xffff
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=-1 then ft=nil end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local dg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,sc,sc2,e,tp,ft)
	local dc=dg:GetFirst()
	if dc then
		Duel.HintSelection(dg)
		if Duel.SendtoDeck(dc,nil,2,REASON_EFFECT)>0 and ft then
			local lv=dc:GetLevel()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,sc2,lv,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
