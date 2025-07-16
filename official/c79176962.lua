--旋風機ストリボーグ
--Fantastic Striborg
local s,id=GetID()
function s.initial_effect(c)
	--Monsters Tributed for the face-up Tribute Summon of this card are returned to the hand instead of going to the GY
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetCode(EFFECT_MATERIAL_CHECK)
	e0a:SetValue(s.valcheck)
	c:RegisterEffect(e0a)
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetCode(EFFECT_SUMMON_COST)
	e0b:SetOperation(function() e0a:SetLabel(1) end)
	c:RegisterEffect(e0b)
	--Return all cards your opponent controls in this card's column to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.Discard())
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.valcheck(e,c)
	if e:GetLabel()==0 then return end
	e:SetLabel(0)
	local mg=c:GetMaterial()
	for mc in mg:Iter() do
		--Monsters Tributed for the face-up Tribute Summon of this card are returned to the hand instead of going to the GY
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_HAND)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		mc:RegisterEffect(e1)
	end
end
function s.thfilter(c,tp)
	return c:IsControler(1-tp) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetColumnGroup():IsExists(s.thfilter,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local colg=c:GetColumnGroup():Match(Card.IsControler,nil,1-tp)
	if c:IsControler(1-tp) then colg:AddCard(c) end
	if #colg>0 then
		Duel.SendtoHand(colg,nil,REASON_EFFECT)
	end
end