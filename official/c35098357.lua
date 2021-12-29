--ウィッチクラフト・コンフュージョン
--Witchcrafter Confusion
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Fusion Monster, including 1+ "Witchcrafter" monster as material
	local e1=Fusion.CreateSummonEff({handler=c,matfilter=s.mfilter,extrafil=s.fextra})
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Add this card from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
	--Lists "Witchcrafter" archetype
s.listed_series={0x128}

function s.mfilter(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsAbleToGrave())
end
function s.checkmat(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,0x128)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil),s.checkmat
end
	--Check for face-up "Witchcrafter" monster and if it's your End Phase
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x128),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsTurnPlayer(tp)
end
	--Activation legality
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_GRAVE)
end
	--Add this card from GY to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,tp,REASON_EFFECT)
	end
end