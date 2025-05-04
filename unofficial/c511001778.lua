--牙鮫帝シャーク・カイゼル (Anime)
--Shark Caesar (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 4 Level 3 monsters
	Xyz.AddProcedure(c,nil,3,4)
	--Gains ATK equal to the difference of the number of materials required for its Summon and the number currently attached x 1000
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(69610924,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(Cost.Detach(1))
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local minct=c.minxyzct
	local atk=(minct-c:GetOverlayCount())*1000
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:UpdateAttack(atk)
	end
end
