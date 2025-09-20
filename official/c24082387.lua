--ミステリーサークル
--Crop Circles
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Alien" monster from your Deck whose Level is equal to the total original Levels of the monsters sent to the GY to activate this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ALIEN}
function s.costfilter(c)
	return c:HasLevel() and c:IsAbleToGraveAsCost() and c:IsMonsterCard()
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,sg:GetSum(Card.GetOriginalLevel))
end
function s.spfilter(c,e,tp,lv)
	return c:IsSetCard(SET_ALIEN) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local cg=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #cg>0 and aux.SelectUnselectGroup(cg,e,tp,1,#cg,s.rescon,0) end
	local g=aux.SelectUnselectGroup(cg,e,tp,1,#cg,s.rescon,1,tp,HINTMSG_TOGRAVE,s.rescon)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetSum(Card.GetOriginalLevel))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==-100
		e:SetLabel(0)
		return res
	end
	Duel.SetTargetParam(e:GetLabel())
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sp_chk=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
		if #g>0 then
			sp_chk=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if sp_chk==0 then
		Duel.Damage(tp,2000,REASON_EFFECT)
	end
end