--Vampire's Curse (Anime)
-- [Monster / Effect]
-- [Zombie:Dark 6* 2000/800]
local s,id=GetID()
function s.initial_effect(c)

	--[Effect e1] Special Summon of Graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetOperation(s.spop)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	--[Effect e3] If its Special Summon, update ATK.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.upcon)
	e3:SetOperation(s.upop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
end


----- ########## < Effect e1 >  ########## -----

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_DESTROY)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	e:SetLabel(e:GetLabel() + 1)
	Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
end

----- ########## < /Effect e1 >  ########## -----


----- ########## < Effect e3 >  ########## -----
function s.upcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function s.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500 * e:GetLabelObject():GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
----- ########## < /Effect e3 >  ########## -----