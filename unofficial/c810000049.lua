--ギア・チェンジャー
--Gear Changer
--Scripted by UnknownGuest
local s,id=GetID()
function s.initial_effect(c)
	--If your opponent controls a monster and you control no monsters, you can Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--When this card is Summoned this way, increase this card's Level by the Level of 1 face-up monster your opponent controls.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1) end)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,c,1,tp,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local gct=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):FilterCount(aux.AND(Card.IsFaceup,Card.HasLevel),nil)
	if gct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,Card.HasLevel),tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	local lv=tc:GetLevel()
	Duel.HintSelection(tc)
	if tc and tc:IsFaceup() and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
