--決闘進化－バスター・ゾーン
--Duel Evolution - Assault Zone
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: You can add 1 monster that mentions "Assault Mode Activate" from your Deck or GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--"/Assault Mode" monsters cannot be destroyed by battle or your opponent's card effects during the turn they are Special Summoned
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2a:SetRange(LOCATION_FZONE)
	e2a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2a:SetTarget(function(e,c) return c:IsSetCard(SET_ASSAULT_MODE) and c:IsStatus(STATUS_SPSUMMON_TURN) end)
	e2a:SetValue(1)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2b:SetValue(aux.indoval)
	c:RegisterEffect(e2b)
	--Apply an "once this turn, you can activate "Assault Mode Activate" by Tributing a Synchro Monster in the Extra Deck" effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCost(Cost.PayLP(2000))
	e3:SetCountLimit(1,{id,1})
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_ASSAULT_MODE}
s.listed_series={SET_ASSAULT_MODE}
function s.thfilter(c)
	return c:IsMonster() and c:ListsCode(CARD_ASSAULT_MODE) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,3))
	--Once this turn, you can activate "Assault Mode Activate" by Tributing a Synchro Monster in the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_EXTRA_RELEASE_NONSUM)
	e1:SetTargetRange(LOCATION_EXTRA,0)
	e1:SetCondition(function(e) return not Duel.HasFlagEffect(e:GetHandlerPlayer(),id) end)
	e1:SetValue(s.relval)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Manually handling the OPT of the above effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return s.relval(e,re,r) and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA) end)
	e2:SetOperation(function(e,tp) Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.relval(e,re,r,rp)
	return re and re:IsActivated() and (r&REASON_COST)>0 and re:GetHandler():IsCode(CARD_ASSAULT_MODE)
end