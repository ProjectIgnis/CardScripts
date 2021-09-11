--Go, Gradius!
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={10992251,14291024,93130021,10642488,5494820,54289683}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local b1=Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,10992251),tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,54289683)
	local b2= #g==1 and g:GetFirst():GetOriginalCode()==10992251
	--condition
	return aux.CanActivateSkill(tp) and (b1 or b2)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	--Change Power Capsule
	local b1=Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,10992251),tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,54289683)
	--Change Gradius
	local b2= #g==1 and g:GetFirst():GetOriginalCode()==10992251
	--Transform!
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,3))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,3))
	end
	if not (b1 or b2) then return false end
	if (b1 and op==0) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		local tc=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND,0,1,1,nil,54289683):GetFirst()
		if tc then
			local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
			if opt==0 then
				tc:Recreate(14291024,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
			elseif opt==1 then
				tc:Recreate(5494820,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
			end
		end
	 else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		local tc=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsOriginalCode,10992251),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then
			local opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
			if opt==0 then 
				tc:Recreate(93130021,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
			else
				tc:Recreate(10642488,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
			end
		end
	end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
end
