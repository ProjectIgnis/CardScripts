--黒薔薇の華園
--Black Rose Garden
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: You can add 1 "Rose Dragon" monster from your Deck or GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE) end)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Face-up monsters on the field become Plant monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(RACE_PLANT)
	c:RegisterEffect(e2)
	--Inflict 100 damage to your opponent for each Plant monster in your GY and banishment, then if this card was destroyed by the effect of "Black Rose Dragon", inflict 2400 damage to your opponent
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ROSE_DRAGON}
s.listed_names={CARD_BLACK_ROSE_DRAGON}
function s.thfilter(c)
	return c:IsSetCard(SET_ROSE_DRAGON) and c:IsMonster() and c:IsAbleToHand()
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
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=100*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_PLANT),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if e:GetHandler():IsReason(REASON_EFFECT) and re:GetHandler():IsCode(CARD_BLACK_ROSE_DRAGON) then
		e:SetLabel(1)
		if dam>0 then dam=dam+2400 end
	else
		e:SetLabel(0)
	end
	Duel.SetTargetPlayer(1-tp)
	if dam>0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=100*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_PLANT),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if dam>0 and Duel.Damage(p,dam,REASON_EFFECT)>0 and e:GetLabel()==1 then
		Duel.BreakEffect()
		Duel.Damage(p,2400,REASON_EFFECT)
	end
end