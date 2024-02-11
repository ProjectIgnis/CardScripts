--双頭竜キング・レックス
--Double-Headed Dino King Rex
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from the hand if you control no monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Destroy 1 monster on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.desfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_DINOSAUR),tp,LOCATION_MZONE,0,nil):GetSum(Card.GetAttack)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,atk) end
	if chk==0 then return atk>0 and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end