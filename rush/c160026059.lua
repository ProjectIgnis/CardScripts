--インスタント・ギフト
--Instant Gift
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e,tp,...)
    local named_mats={...}
    for key,current_mat in pairs(named_mats) do
        if c:IsCode(current_mat) then
            return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        end
    end
    return false
end
function s.revealfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsLevel(7) and c:IsRace(RACE_WARRIOR) and c:IsAttack(2500) and not c:IsPublic()
		and c.material and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,table.unpack(c.material))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.chkfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local fc=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	Duel.ConfirmCards(1-tp,fc)
	Duel.ShuffleExtra(tp)
	--To populate the table with valid declarable names
	local announcement_filter={}
	for _,name in pairs(fc.material) do
		if Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,name) then
			if #announcement_filter==0 then
				table.insert(announcement_filter,name)
				table.insert(announcement_filter,OPCODE_ISCODE)
			else
				table.insert(announcement_filter,name)
				table.insert(announcement_filter,OPCODE_ISCODE)
				table.insert(announcement_filter,OPCODE_OR)
			end
		end
	end
	--Effect
	local declared_name=Duel.AnnounceCard(tp,announcement_filter)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.chkfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,declared_name)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	--Prevent non-Warriors from attacking
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ftarget)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.ftarget(e,c)
	return not c:IsRace(RACE_WARRIOR)
end