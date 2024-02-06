--古代の進軍
--Ancient Gear Advance
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Search 1 "Ancient Gear" Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Draw 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.drwcost)
	e2:SetTarget(s.drwtg)
	e2:SetOperation(s.drwop)
	c:RegisterEffect(e2)
	--Register when a player Sets a card
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_MSET)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1) end)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SSET)
		Duel.RegisterEffect(ge2,0)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_CHANGE_POS)
		ge3:SetOperation(s.checkposop)
		Duel.RegisterEffect(ge3,0)
		local ge4=ge1:Clone()
		ge4:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge4:SetOperation(s.checksumop)
		Duel.RegisterEffect(ge4,0)
	end)
end
s.listed_names={CARD_ANCIENT_GEAR_GOLEM,id}
s.listed_series={SET_ANCIENT_GEAR}
function s.checkposfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown()
end
function s.checkposop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.checkposfilter,1,nil) then
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.checksumop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsFacedown,1,nil) then
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	--Cannot Set cards the turn you activate this card
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTarget(function(_,_,_,_,sumpos) return (sumpos&POS_FACEDOWN)>0 end)
	Duel.RegisterEffect(e4,tp)
end
function s.thfilter(c)
	return c:IsSetCard(SET_ANCIENT_GEAR) and c:IsSpellTrap() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.drwcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	local c=e:GetHandler()
	--"Ancient Gear Golem" or monsters that mention it can be Normal Summoned without Tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCondition(s.ntcon)
	e1:SetTarget(aux.FieldSummonProcTg(s.nttg))
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,4))
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return (c:IsCode(CARD_ANCIENT_GEAR_GOLEM) or c:ListsCode(CARD_ANCIENT_GEAR_GOLEM)) and c:IsLevelAbove(5)
end