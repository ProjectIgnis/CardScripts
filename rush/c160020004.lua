--カオス・クールスター
--Chaos Coolstars
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Draw and become 2 tributes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_GALACTICA_OBLIVION,160010025}
function s.cfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and c:IsAbleToGraveAsCost()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_COST)<1 then return end
	--Effect
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
	e:GetHandler():AddDoubleTribute(id,s.otfilter,s.eftg,RESETS_STANDARD_PHASE_END,FLAG_DOUBLE_TRIB_OBLIVION,FLAG_DOUBLE_TRIB_REQUIEM)
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_OBLIVION,FLAG_DOUBLE_TRIB_REQUIEM) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsCode(CARD_GALACTICA_OBLIVION,160010025) and c:IsSummonableCard()
end