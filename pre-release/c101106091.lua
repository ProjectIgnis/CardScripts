--
--Beetrooper Squad
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={64213018}
function s.costfilter(c,tp)
	return c:IsMonster() and c:IsRace(RACE_INSECT) and not c:IsType(TYPE_TOKEN) and c:GetBaseAttack()>=1000
		and Duel.GetMZoneCount(tp,c)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	if chk==0 then return true end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=0 then return false end
		return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,tp)
			and Duel.IsPlayerCanSpecialSummonMonster(tp,64213018,0x172,TYPES_TOKEN,1000,1000,3,RACE_INSECT,ATTRIBUTE_EARTH)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tg=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,tp)
	e:SetLabel(tg:GetFirst():GetBaseAttack()//1000)
	Duel.Release(tg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,64213018,0x172,TYPES_TOKEN,1000,1000,3,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	ft=math.min(ft,e:GetLabel())
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft>1 then ft=Duel.AnnounceNumberRange(tp,1,ft) end
	local sg=Group.CreateGroup()
	for i=1,ft do
		local token=Duel.CreateToken(tp,64213018)
		sg:AddCard(token)
	end
	if #sg==0 then return end
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end