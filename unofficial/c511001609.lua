--ランクゲイザー
--Rank Gazer
local s,id=GetID()
function s.initial_effect(c)
	--Gain LP equal to the total Ranks of all Xyz Monsters you control x 300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsXyzMonster),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	local sum=g:GetSum(Card.GetRank)*300
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,sum)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsXyzMonster),tp,LOCATION_MZONE,0,nil)
	if#g==0 then return end
	local sum=g:GetSum(Card.GetRank)*300
	Duel.Recover(p,sum,REASON_EFFECT)
	--This turn if an Xyz Monster(s) you control leaves the field, you can Special Summon 1 Xyz Monster from your Extra Deck, and attach that monster(s) to it as Xyz Material
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spconfilter(c,tp)
    return c:IsXyzMonster() and c:IsPreviousControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.attachfilter(c,tc,e,tp)
    return c:IsXyzMonster() and c:IsPreviousControler(tp) and c:IsCanBeXyzMaterial(tc,tp,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
end
function s.spfilter(c,e,tp)
    return c:IsXyzMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(102380,0)) then
        Duel.Hint(HINT_CARD,0,id)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local xyzc=g:Select(tp,1,1,nil):GetFirst()
        local attach_group=eg:Filter(aux.NecroValleyFilter(s.attachfilter),nil,xyzc,e,tp,REASON_EFFECT)
        Duel.SpecialSummon(xyzc,0,tp,tp,false,false,POS_FACEUP)
        Duel.Overlay(xyzc,attach_group,true)
    end
end
