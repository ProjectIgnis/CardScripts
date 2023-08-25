--振楽姫チューバルディッシュ
--Tubardiche the Music Princess
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Add card to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_WARRIOR),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.thfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelAbove(7) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local sg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,nil)
	if #sg>0 then
		local tg=aux.SelectUnselectGroup(sg,1,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(s.thfilter,nil)==1 and sg:FilterCount(s.thfilter2,nil)==1
end
function s.aclimit(e,re,tp)
	return re:IsMonsterEffect() and not (re:GetHandler():IsAttribute(ATTRIBUTE_WIND) and re:GetHandler():IsRace(RACE_WARRIOR|RACE_BEAST))
end