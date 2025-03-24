--起動兵士デッドリボルバー
--Boot-Up Soldier - Dread Dynamo
local s,id=GetID()
function s.initial_effect(c)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(2000)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GADGET}
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GADGET),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end