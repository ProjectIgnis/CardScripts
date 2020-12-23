--白の烙印
--Stigmata of White
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	local e1=Fusion.CreateSummonEff(c,nil,nil,s.fextra)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end
function s.filterchk(c)
	return c:IsCode(CARD_ALBAZ) and c:IsLocation(LOCATION_HAND+LOCATION_MZONE)
end
function s.fcheck(tp,sg,fc)
	if not sg:IsExists(Card.IsRace,1,nil,RACE_DRAGON) then
		return false
	end
	if sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		return sg:IsExists(s.filterchk,1,nil) end
	return true
end
function s.fextra(e,tp,mg)
	if mg:IsExists(s.filterchk,1,nil) then
		local eg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil,s.fcheck
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_COST) and re and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsCode(CARD_ALBAZ) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_TOFIELD)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,id+100)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(s.settg)
		e1:SetOperation(s.setop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end
