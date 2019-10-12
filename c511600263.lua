--海晶乙女 クラウンテイル
--Marincess Crown Tail
--scripted by Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(alias,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--prevent damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(alias,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0x12b}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttackTarget()
	if not c then return false end
	if not Duel.GetAttackTarget():IsControler(tp) then c=Duel.GetAttacker() end
	return c:IsSetCard(0x12b) and c:IsRelateToBattle() and not c:GetBattleTarget():IsControler(tp)
end
function s.cfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.damop)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
	if c:IsRelateToEffect(e) then e1:SetLabelObject(c) end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,Duel.GetBattleDamage(tp)/2)
	if e:GetLabelObject() then
		Duel.BreakEffect()
		Duel.SpecialSummon(e:GetLabelObject(),0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_AVAILABLE_BD)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(4016,7))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.filter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_LINK) and c:IsType(TYPE_MONSTER) and c:GetLink()>0
end
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_BATTLE~=REASON_BATTLE then return val end
	local g=Duel.GetMatchingGroup(s.filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	local g2=g:Clone()
	for c in aux.Next(g) do
		if g2:FilterCount(Card.IsCode,nil,c:GetCode())>1 then
			g2:RemoveCard(c)
		end
	end
	local dam=g2:GetSum(Card.GetLink)*1000
	if val<=dam then return 0 else return val end
end
