--Cyberdark Scheme
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_series={SET_CYBERDARK}
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_CYBERDARK) and c:IsAbleToHandAsCost()
end
function s.nsfilter(c)
	return c:IsSetCard(SET_CYBERDARK) and c:IsSummonable(true,nil)
end
function s.tgfilter(c)
	return c:IsOriginalType(TYPE_MONSTER) and (c:GetEquipTarget():IsSetCard(SET_CYBERDARK) and c:GetEquipTarget():IsType(TYPE_FUSION)) and c:IsAbleToGraveAsCost()
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAbleToChangeControler()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_STZONE)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_STZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil) and ft>-1 and Duel.GetFlagEffect(tp,id)==0
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_STZONE)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_STZONE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil) and ft>-1 and Duel.GetFlagEffect(tp,id)==0
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc:IsFacedown() then
			Duel.ConfirmCards(tp,tc)
		end
		if tc and Duel.SendtoHand(tc,tp,REASON_COST)>0 and tc:IsLocation(LOCATION_HAND) and Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
			if sc then
				Duel.Summon(tp,sc,true,nil)
			end
		end
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local gc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_STZONE,0,1,1,nil):GetFirst()
		if Duel.SendtoGrave(gc,REASON_COST)>0 then
			local ec=gc:GetPreviousEquipTarget()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
			local sc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
			if sc and sc:IsAbleToChangeControler() then
				Duel.HintSelection(sc)
				local atk=sc:GetBaseAttack()
				s.eqop(ec,e,tp,sc,atk)
			end
		end
	end	 
end
function s.eqop(c,e,tp,tc,atk)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,nil,false) then return end
	--ATK gain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e2)
end
function s.eqlimit(e,c)
	return c:GetControler()==e:GetHandlerPlayer()
end