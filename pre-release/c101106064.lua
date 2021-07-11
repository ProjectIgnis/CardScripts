--音速を追う者
--Sonic Tracker
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreater({handler=c,filter=aux.FilterBoolFunction(Card.IsCode,101106037),stage2=s.stage2})
	--to gy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.gytg)
	e1:SetOperation(s.gyop)
	c:RegisterEffect(e1)
end
s.fit_monster={101106037}
s.listed_names={101106037}
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(mat:GetSum(Card.GetLevel))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
function s.gyfilter1(c,tp)
	return c:IsFaceup() and c:IsRitualMonster() 
		and Duel.IsExistingMatchingCard(s.gyfilter2,tp,LOCATION_DECK,0,1,nil,c)
end
function s.gyfilter2(c,tc)
	return c:IsRitualMonster() and c:IsAbleToGrave()
		and (c:IsAttribute(tc:GetAttribute()) or c:IsRace(tc:GetRace()))
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.gyfilter1(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.gyfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.gyfilter2,tp,LOCATION_DECK,0,1,1,nil,tc)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end