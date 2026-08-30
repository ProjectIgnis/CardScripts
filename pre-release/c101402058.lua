--竜都アトランティス
--Atlantis, the Dragon City
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--While a monster that mentions "Atlantis, the Dragon City" is on the field, reduce the Levels of all monsters in both players' hands and fields by 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,LOCATION_HAND|LOCATION_MZONE)
	e1:SetCondition(function()
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.ListsCode,CARD_ATLANTIS_THE_DRAGON_CITY),0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end)
	e1:SetValue(-1)
	c:RegisterEffect(e1)
	--If you Link Summon a "Daedalus" monster, you can reduce the material requirement listed on it by 1 and Link Summon it with 1 less material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(CARD_ATLANTIS_THE_DRAGON_CITY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	--If this card is in your GY and you control "Umi": You can place this card face-up on your field. You can only use this effect of "Atlantis, the Dragon City" once per turn.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_UMI),tp,LOCATION_ONFIELD,0,1,nil)
	end)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return c:CheckUniqueOnField(tp) end
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
	end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	end)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_ATLANTIS_THE_DRAGON_CITY,CARD_UMI}
s.listed_series={SET_DAEDALUS}