--Tribal Synergy
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(ep,id)>0 and Duel.GetFlagEffect(ep,id+1)>0 then return end
	local b1=(Duel.GetFlagEffect(ep,id)==0 and Duel.IsExistingMatchingCard(s.Amafilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,1))
	local b2=(Duel.GetFlagEffect(ep,id+1)==0 and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x4) and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x64) and Duel.IsPlayerCanDraw(tp,2))
	local b3= b1 and b2 and Duel.IsPlayerCanDraw(tp,3)
	--condition
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.Amafilter(c)
	return c:IsSetCard(0x4) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
	and Duel.IsExistingMatchingCard(s.Hapfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
function s.Hapfilter(c)
	return c:IsSetCard(0x64) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local b1=(Duel.GetFlagEffect(ep,id)==0 and Duel.IsExistingMatchingCard(s.Amafilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,1))
	local b2=(Duel.GetFlagEffect(ep,id+1)==0 and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x4) and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x64) and Duel.IsPlayerCanDraw(tp,2))
	local b3= b1 and b2 and Duel.IsPlayerCanDraw(tp,3)
	local p=0
	if b3 then
		p=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		p=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		p=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if p==0 then
		local g1=Duel.SelectMatchingCard(tp,s.Amafilter,tp,LOCATION_HAND,0,1,1,nil)
		local g2=Duel.SelectMatchingCard(tp,s.Hapfilter,tp,LOCATION_HAND,0,1,1,g1:GetFirst())
		g1:Merge(g2)
		Duel.ConfirmCards(1-tp,g1)
		Duel.Draw(tp,1,REASON_EFFECT)
		-- opd register
		Duel.RegisterFlagEffect(ep,id,0,0,0)
	elseif p==1 then
		Duel.Draw(tp,2,REASON_EFFECT)
		-- opd register
		Duel.RegisterFlagEffect(ep,id+1,0,0,0)
	else
		local g1=Duel.SelectMatchingCard(tp,s.Amafilter,tp,LOCATION_HAND,0,1,1,nil)
		local g2=Duel.SelectMatchingCard(tp,s.Hapfilter,tp,LOCATION_HAND,0,1,1,g1:GetFirst())
		g1:Merge(g2)
		Duel.ConfirmCards(1-tp,g1)
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.Draw(tp,2,REASON_EFFECT)
		-- opd register
		Duel.RegisterFlagEffect(ep,id,0,0,0)
		Duel.RegisterFlagEffect(ep,id+1,0,0,0)
	end
end
