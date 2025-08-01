--ナーゲルの守護天
--Nagel's Protection
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--"Tindangle" monsters in your Main Monster Zones cannot be destroyed by battle or your opponent's card effects
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetTargetRange(LOCATION_MMZONE,0)
	e1a:SetTarget(function(e,c) return c:IsSetCard(SET_TINDANGLE) end)
	e1a:SetValue(1)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1b:SetValue(aux.indoval)
	c:RegisterEffect(e1b)
	--Once per turn, if your "Tindangle" monster inflicts battle damage to your opponent, the damage is doubled
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2a:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetTargetRange(LOCATION_MZONE,0)
	e2a:SetCondition(function(e) return not e:GetHandler():HasFlagEffect(id) end)
	e2a:SetTarget(function(e,c) return c:IsSetCard(SET_TINDANGLE) end)
	e2a:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2a)
	--Register if your "Tindangle" monster inflicts battle damage to your opponent
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2b:SetRange(LOCATION_SZONE)
	e2b:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp and eg:GetFirst():IsSetCard(SET_TINDANGLE) end)
	e2b:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1) end)
	c:RegisterEffect(e2b)
	--Add 1 "Nagel's Protection" from your Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.AND(Cost.SelfBanish,Cost.Discard(function(c) return c:IsSetCard(SET_TINDANGLE) end)))
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_TINDANGLE}
s.listed_names={id}
function s.thfilter(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end