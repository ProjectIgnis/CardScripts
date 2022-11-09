--Deck Master Effect: Strike Ninja
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_series={0x2b,0x61}
s.listed_names={41006930}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetFlagEffect(ep,id)==0 and Duel.IsExistingMatchingCard(s.ctrlfilter,tp,0,LOCATION_SZONE,1,nil) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local b2=Duel.GetFlagEffect(ep,id+100)==0 and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetLP(tp)<=1500 and (b1 or b2)
end
--Effects
function s.ctrlfilter(c)
	return c:IsFacedown() and c:IsAbleToChangeControler()
end
function s.tgfilter(c)
	return (c:IsSetCard(0x2b) or c:IsSetCard(0x61)) and c:IsAbleToGrave()
end
function s.rmvfilter(c)
	return c:GetOwner()~=c:GetControler() and c:IsAbleToRemove()
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local b1=Duel.GetFlagEffect(ep,id)==0 and Duel.IsExistingMatchingCard(s.ctrlfilter,tp,0,LOCATION_SZONE,1,nil) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local b2=Duel.GetFlagEffect(ep,id+100)==0 and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if b1 and b2 then
		p=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		p=Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif b2 then
		p=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if p==0 then
		Duel.RegisterFlagEffect(ep,id,0,0,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 and Duel.SendtoGrave(g,REASON_COST)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local sg=Duel.SelectMatchingCard(tp,s.ctrlfilter,tp,0,LOCATION_SZONE,1,1,nil,e,tp)
			if #sg>0 then
				Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
			end
		end
	elseif p==1 then
		Duel.RegisterFlagEffect(ep,id+100,0,0,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tc=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
			local sc=Duel.CreateToken(tp,41006930)
			if sc then 
				Duel.MoveToField(sc,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
			end
		end
	else
		Duel.RegisterFlagEffect(ep,id,0,0,0)
		Duel.RegisterFlagEffect(ep,id+100,0,0,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,loc,1,1,nil)
		if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local sg=Duel.SelectMatchingCard(tp,s.ctrlfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.GetControl(sg,tp)
			end
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tc=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
			local sc=Duel.CreateToken(tp,41006930)
			if sc then 
				Duel.MoveToField(sc,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
			end
		end
	end
end
